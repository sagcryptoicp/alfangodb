import InputTypes "../types/input";
import OutputTypes "../types/output";
import Database "../types/database";
import Datatypes "../types/datatype";
import Commons "commons";
import Utils "../utils";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Time "mo:base/Time";
import Map "mo:map/Map";
import Set "mo:map/Set";
import { thash } "mo:map/Map";

module {

    public func addAttribute({
        addAttributeInput: InputTypes.AddAttributeInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.AddAttributeOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, addAttributeInput.databaseName)) {
            Debug.print("database does not exist");
            return #err([ "database does not exist" ]);
        };

        let errorBuffer = Buffer.Buffer<Text>(0);
        ignore do ?{
            let database = Map.get(databases, thash, addAttributeInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, addAttributeInput.tableName)) {
                errorBuffer.add("table "# debug_show(addAttributeInput.tableName) # " does not exist");
                Debug.print("error(s) adding attribute: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            // get table
            let table = Map.get(database.tables, thash, addAttributeInput.tableName)!;

            // check if attribute exists
            if (Map.has(table.metadata.attributesMap, thash, addAttributeInput.attribute.name)) {
                errorBuffer.add("attribute "# debug_show(addAttributeInput.attribute.name) # " already exists");
                Debug.print("error(s) adding attribute: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            // initialize unique attribute indexes
            if (addAttributeInput.attribute.unique) {
                Map.set(table.indexes, thash, addAttributeInput.attribute.name, {
                    attributeName = addAttributeInput.attribute.name;
                    items = Map.new<Datatypes.AttributeDataValue, Set.Set<Text>>();
                });
            };

            // add attribute to metadata
            Map.set(table.metadata.attributesMap, thash, addAttributeInput.attribute.name, addAttributeInput.attribute);

            return #ok({
                databaseName = addAttributeInput.databaseName;
                tableName = addAttributeInput.tableName;
                attributeName = addAttributeInput.attribute.name;
            });
        };

        Prelude.unreachable();
    };

    public func dropAttribute({
        dropAttributeInput: InputTypes.DropAttributeInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.DropAttributeOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, dropAttributeInput.databaseName)) {
            Debug.print("database does not exist");
            return #err([ "database does not exist" ]);
        };

        let errorBuffer = Buffer.Buffer<Text>(0);
        ignore do ?{
            let database = Map.get(databases, thash, dropAttributeInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, dropAttributeInput.tableName)) {
                errorBuffer.add("table "# debug_show(dropAttributeInput.tableName) # " does not exist");
                Debug.print("error(s) dropping attribute: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            // get table
            let table = Map.get(database.tables, thash, dropAttributeInput.tableName)!;

            // check if attribute does not exist
            if (not Map.has(table.metadata.attributesMap, thash, dropAttributeInput.attributeName)) {
                errorBuffer.add("attribute "# debug_show(dropAttributeInput.attributeName) # " does not exist");
                Debug.print("error(s) dropping attribute: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            // remove attribute from indexes
            if (Map.has(table.indexes, thash, dropAttributeInput.attributeName)) {
                Map.delete(table.indexes, thash, dropAttributeInput.attributeName);
            };

            // remove attribute from metadata
            Map.delete(table.metadata.attributesMap, thash, dropAttributeInput.attributeName);

            // remove attribute from items
            for (item in Map.vals(table.items)) {
                Map.delete(item.attributeDataValueMap, thash, dropAttributeInput.attributeName);
            };

            return #ok({
                databaseName = dropAttributeInput.databaseName;
                tableName = dropAttributeInput.tableName;
                attributeName = dropAttributeInput.attributeName;
            });
        };

        Prelude.unreachable();
    };

    public func updateItem({
        updateItemInput: InputTypes.UpdateItemInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.UpdateItemOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, updateItemInput.databaseName)) {
            Debug.print("database does not exist");
            return #err([ "database does not exist" ]);
        };

        let errorBuffer = Buffer.Buffer<Text>(0);
        ignore do ?{
            let database = Map.get(databases, thash, updateItemInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, updateItemInput.tableName)) {
                errorBuffer.add("table "# debug_show(updateItemInput.tableName) # " does not exist");
                Debug.print("error(s) creating item: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            // get table
            let table = Map.get(database.tables, thash, updateItemInput.tableName)!;

            // check if item exists
            if (not Map.has(table.items, thash, updateItemInput.id)) {
                errorBuffer.add("item "# debug_show(updateItemInput.id) # " does not exist");
                Debug.print("error(s) creating item: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            let attributeDataValueMap = HashMap.fromIter<Text, Datatypes.AttributeDataValue>(updateItemInput.attributeDataValues.vals(), 0, Text.equal, Text.hash);

            //////////////////////////////// START VALIDATION ////////////////////////////////

            // 1. validate item data-type
            let {
                isValidAttributesDataType = validItemDataType;
            } = Commons.validateAttributeDataTypes({
                attributeKeyDataValues = updateItemInput.attributeDataValues;
                attributeNameToMetadataMap = table.metadata.attributesMap;
            });
            if (not validItemDataType) {
                errorBuffer.add("At least one update attribute has wrong data-type");
            };

            // 2. validate unique attributes
            let {
                invalidUnquieAttributes;
                uniqueAttributesUnique;
            } = Commons.validateUniqueAttributes({
                attributeKeyDataValues = updateItemInput.attributeDataValues;
                indexes = table.indexes;
                tableMetadata = table.metadata;
            });
            if (not uniqueAttributesUnique) {
                errorBuffer.add("At least one unique update attribute is not unique");
            };

            if (errorBuffer.size() > 0) {
                Debug.print("error(s) creating item: " # debug_show(Buffer.toArray(errorBuffer)));
                return #err(Buffer.toArray(errorBuffer));
            };

            ////////////////////////////////   END VALIDATION    ////////////////////////////////

            let item = Map.get(table.items, thash, updateItemInput.id)!;
            for ((attributeName, updatedAttributeDataValue) in updateItemInput.attributeDataValues.vals()) {
                // update indexes
                ignore do ?{
                    let indexTable = Map.get(table.indexes, thash, attributeName)!;

                    // remove old id from index
                    let oldAttributeDataValue = Map.get(item.attributeDataValueMap, thash, attributeName)!;
                    let oldAttributeDataValueIdSet = Option.get(Map.get(indexTable.items, Utils.DataTypeValueHashUtils, oldAttributeDataValue), Set.new<Text>());
                    Set.delete(oldAttributeDataValueIdSet, thash, updateItemInput.id);

                    // add new id to index
                    let newAttributeDataValueIdSet = Option.get(Map.get(indexTable.items, Utils.DataTypeValueHashUtils, updatedAttributeDataValue), Set.new<Text>());
                    if (Set.size(newAttributeDataValueIdSet) == 0) {
                        Map.set(indexTable.items, Utils.DataTypeValueHashUtils, updatedAttributeDataValue, newAttributeDataValueIdSet);
                    };
                    Set.add(newAttributeDataValueIdSet, thash, updateItemInput.id);
                };

                // update item
                Map.set(item.attributeDataValueMap, thash, attributeName, updatedAttributeDataValue);
            };

            // update updatedAt field
            item.updatedAt := Time.now();

            Debug.print("item updated with id: " # debug_show(updateItemInput.id));
            return #ok({
                id = updateItemInput.id;
                item = Map.toArray(item.attributeDataValueMap);
            });
        };

        Prelude.unreachable();
    };

};