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
import Array "mo:base/Array";
import Option "mo:base/Option";
import Map "mo:map/Map";
import Set "mo:map/Set";
import { thash } "mo:map/Map";

module {

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
            let attributeNameToMetadataMap = HashMap.fromIter<Text, Database.AttributeMetadata>(
                Array.map<Database.AttributeMetadata, (Text, Database.AttributeMetadata)>(table.metadata.attributes, func attributeMetadata = (attributeMetadata.name, attributeMetadata)).vals(),
                table.metadata.attributes.size(), Text.equal, Text.hash
            );
            //////////////////////////////// START VALIDATION ////////////////////////////////

            // 1. validate item data-type
            let {
                isValidAttributesDataType = validItemDataType;
            } = Commons.validateAttributeDataTypes({
                attributeKeyDataValues = updateItemInput.attributeDataValues;
                attributeNameToMetadataMap;
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
            Debug.print("item updated with id: " # debug_show(updateItemInput.id));
            return #ok({
                id = updateItemInput.id;
                item = Map.toArray(item.attributeDataValueMap);
            });
        };

        Prelude.unreachable();
    };

};