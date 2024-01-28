import Database "../types/database";
import Datatypes "../types/datatype";
import InputTypes "../types/input";
import OutputTypes "../types/output";
import Commons "commons";
import Utils "../utils";
import Map "mo:map/Map";
import Set "mo:map/Set";
import { thash } "mo:map/Map";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Iter "mo:base/Iter";
import Time "mo:base/Time";

module {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func createDatabase({
        createDatabaseInput: InputTypes.CreateDatabaseInputType;
        alfangoDB: Database.AlfangoDB;
    }) {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (Map.has(databases, thash, createDatabaseInput.name)) {
            Debug.print("database already exists");
            return;
        };

        // create database
        let database : Database.Database = {
            name = createDatabaseInput.name;
            tables = Map.new<Text, Database.Table>();
        };

        // add database to databases
        Map.set(databases, thash, database.name, database);
        Debug.print("database created with name: " # debug_show(database.name));
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func createTable({
        createTableInput: InputTypes.CreateTableInputType;
        alfangoDB: Database.AlfangoDB;
    }) {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, createTableInput.databaseName)) {
            Debug.print("database does not exist");
            return;
        };
 
        ignore do ?{
            let database = Map.get(databases, thash, createTableInput.databaseName)!;

            // check if table exists
            if (Map.has(database.tables, thash, createTableInput.name)) {
                Debug.print("table already exists");
                return;
            };

            // initialize indexes
            let indexes = Map.new<Text, Database.Index>();
            for (indexMetadata in createTableInput.indexes.vals()) {
                Map.set(indexes, thash, indexMetadata.attributeName, { items = Map.new<Datatypes.AttributeDataValue, Set.Set<Text>>() });
            };

            // initialize unique attribute indexes
            for (attributeMetadata in createTableInput.attributes.vals()) {
                if (attributeMetadata.unique) {
                    Map.set(indexes, thash, attributeMetadata.name, { items = Map.new<Datatypes.AttributeDataValue, Set.Set<Text>>() });
                };
            };

            // create table
            let table : Database.Table = {
                name = createTableInput.name;
                metadata = {
                    attributes = createTableInput.attributes;
                    indexes = createTableInput.indexes;
                };
                items = Map.new<Text, Database.Item>();
                indexes;
            };

            // add table to database
            Map.set(database.tables, thash, table.name, table);
            Debug.print("table created with name: " # debug_show(table.name));
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func createItem({
        createItemInput: InputTypes.CreateItemInputType;
        alfangoDB: Database.AlfangoDB;
    }) : async OutputTypes.CreateItemOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, createItemInput.databaseName)) {
            Debug.print("database does not exist");
            return #err([ "database does not exist" ]);
        };

        let errorBuffer = Buffer.Buffer<Text>(0);
        ignore do ?{
            let database = Map.get(databases, thash, createItemInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, createItemInput.tableName)) {
                errorBuffer.add("table "# debug_show(createItemInput.tableName) # " does not exist");
                Debug.print("error(s) creating item: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            // get table
            let table = Map.get(database.tables, thash, createItemInput.tableName)!;

            let attributeDataValueMap = HashMap.fromIter<Text, Datatypes.AttributeDataValue>(createItemInput.attributeDataValues.vals(), 0, Text.equal, Text.hash);
            //////////////////////////////// START VALIDATION ////////////////////////////////
            let attributeNameToMetadataMap = HashMap.fromIter<Text, Database.AttributeMetadata>(
                Array.map<Database.AttributeMetadata, (Text, Database.AttributeMetadata)>(table.metadata.attributes, func attributeMetadata = (attributeMetadata.name, attributeMetadata)).vals(),
                table.metadata.attributes.size(), Text.equal, Text.hash
            );

            // 1. validate item data-type
            let {
                isValidAttributesDataType = validItemDataType;
            } = Commons.validateAttributeDataTypeBulk({
                attributeDataValues = createItemInput.attributeDataValues;
                attributeNameToMetadataMap;
            });
            if (not validItemDataType) {
                errorBuffer.add("At least one attribute has wrong data-type");
            };

            // 2. validate required attributes
            let {
                actualRequiredAttributes;
                requiredAttributesPresent;
            } = validateRequiredAttributes({
                attributeDataValues = createItemInput.attributeDataValues;
                tableMetadata = table.metadata;
            });
            if (not requiredAttributesPresent) {
                errorBuffer.add("At least one required attribute is missing");
            };

            // 3. validate unique attributes
            let {
                invalidUnquieAttributes;
                uniqueAttributesUnique;
            } = validateUniqueAttributes({
                attributeDataValues = createItemInput.attributeDataValues;
                indexes = table.indexes;
                tableMetadata = table.metadata;
            });
            if (not uniqueAttributesUnique) {
                errorBuffer.add("At least one unique attribute is not unique");
            };

            if (errorBuffer.size() > 0) {
                Debug.print("error(s) creating item: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };
            ////////////////////////////////   END VALIDATION    ////////////////////////////////

            let newItemId = await Utils.generateULIDAsync();

            // add indexes
            for (indexMetadata in table.metadata.indexes.vals()) {
                ignore do ?{
                    let attributeName = indexMetadata.attributeName;
                    let attributeValue = attributeDataValueMap.get(attributeName)!;
                    let indexItems = Map.get(table.indexes, thash, attributeName)!.items;
                    let idSet = Option.get(Map.get(indexItems, Utils.DataTypeValueHashUtils, attributeValue), Set.new<Text>());
                    if (Set.size(idSet) == 0) {
                        Map.set(indexItems, Utils.DataTypeValueHashUtils, attributeValue, idSet);
                    };
                    Set.add(idSet, thash, newItemId);
                };
            };

            // add unique attribute indexes
            for (attributeMetadata in table.metadata.attributes.vals()) {
                if (attributeMetadata.unique) {
                    ignore do ?{
                        let attributeName = attributeMetadata.name;
                        let attributeValue = attributeDataValueMap.get(attributeName)!;
                        let indexItems = Map.get(table.indexes, thash, attributeName)!.items;
                        let idSet = Option.get(Map.get(indexItems, Utils.DataTypeValueHashUtils, attributeValue), Set.new<Text>());
                        if (Set.size(idSet) == 0) {
                            Map.set(indexItems, Utils.DataTypeValueHashUtils, attributeValue, idSet);
                        };
                        Set.add(idSet, thash, newItemId);
                    };
                };
            };         

            // create item
            let item : Database.Item = {
                id = newItemId;
                attributeDataValueMap = Map.fromIter<Text, Datatypes.AttributeDataValue>(Iter.fromArray(createItemInput.attributeDataValues), thash);
                previousAttributeDataValueMap = Map.new<Text, Datatypes.AttributeDataValue>();
                createdAt = Time.now();
                var updatedAt = Time.now();
            };

            // add item to table
            Map.set(table.items, thash, item.id, item);
            Debug.print("item created with id: " # debug_show(item.id));
            return #ok(item.id);
        };

        Prelude.unreachable();
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private func validateRequiredAttributes({
        attributeDataValues: [ (Text, Datatypes.AttributeDataValue) ];
        tableMetadata: Database.TableMetadata;
    }) : {
        actualRequiredAttributes : [ Text ];
        requiredAttributesPresent : Bool;
    } {
        let expectedRequiredAttributes = Array.filter<Database.AttributeMetadata>(tableMetadata.attributes, func attributeMetadata = attributeMetadata.required);
        let actualRequiredAttributes = Buffer.Buffer<Text>(0);

        for ((attributeName, _) in attributeDataValues.vals()) {
            if (Option.isSome(Array.find<Database.AttributeMetadata>(expectedRequiredAttributes, func attributeMetadata = attributeMetadata.name == attributeName))) {
                actualRequiredAttributes.add(attributeName);
            };
        };

        return {
            actualRequiredAttributes = Buffer.toArray(actualRequiredAttributes);
            requiredAttributesPresent = expectedRequiredAttributes.size() == actualRequiredAttributes.size();
        };
    };

    private func validateUniqueAttributes({
        attributeDataValues: [ (Text, Datatypes.AttributeDataValue) ];
        indexes: Map.Map<Text, Database.Index>;
        tableMetadata: Database.TableMetadata;
    }) : {
        invalidUnquieAttributes : [ Text ];
        uniqueAttributesUnique : Bool;
    } {
        let attributesMetadata = tableMetadata.attributes;
        let attributeDataValueMap = HashMap.fromIter<Text, Datatypes.AttributeDataValue>(attributeDataValues.vals(), 0, Text.equal, Text.hash);
        let invalidUnquieAttributes = Buffer.Buffer<Text>(0);

        label l0 for (attributeMetadata in attributesMetadata.vals()) {
            // check if index is unique
            if (not attributeMetadata.unique) {
                continue l0;
            };

            let attributeName = attributeMetadata.name;
            ignore do ?{
                let indexItems = Map.get(indexes, thash, attributeName)!.items;
                let attributeValue = attributeDataValueMap.get(attributeName)!;

                // check if attribute value has index
                if (Map.has(indexItems, Utils.DataTypeValueHashUtils, attributeValue)) {
                    let idSet = Map.get(indexItems, Utils.DataTypeValueHashUtils, attributeValue)!;
                    if (Set.size(idSet) > 0) {
                        Debug.print("attribute: " # debug_show(attributeName) # " is not unique");
                        invalidUnquieAttributes.add(attributeName);
                    };
                };
            };
        };

        return {
            invalidUnquieAttributes = Buffer.toArray(invalidUnquieAttributes);
            uniqueAttributesUnique = invalidUnquieAttributes.size() == 0;
        };
    };

};