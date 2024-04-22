import Datatypes "../types/datatype";
import Database "../types/database";
import InputTypes "../types/input";
import OutputTypes "../types/output";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";

module {

    public func getTableMetadata({
        getTableMetadataInput : InputTypes.GetTableMetadataInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.GetTableMetadataOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, getTableMetadataInput.databaseName)) {
            Debug.print("database does not exist");
            return null;
        };

        ignore do ?{
            let database = Map.get(databases, thash, getTableMetadataInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, getTableMetadataInput.tableName)) {
                Debug.print("table does not exist");
                return null;
            };

            let table = Map.get(database.tables, thash, getTableMetadataInput.tableName)!;

            return ?{
                databaseName = getTableMetadataInput.databaseName;
                tableName = getTableMetadataInput.tableName;
                metadata = {
                    attributes = Iter.toArray(Map.vals(table.metadata.attributesMap));
                    indexes = table.metadata.indexes;
                };
            };
        };

        return null;
    };

    public func getItemById({
        getItemByIdInput: InputTypes.GetItemByIdInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.GetItemByIdOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, getItemByIdInput.databaseName)) {
            let remark = "database does not exist: " # debug_show(getItemByIdInput.databaseName);
            Debug.print(remark);
            return #err([ remark ]);
        };

        ignore do ?{
            let database = Map.get(databases, thash, getItemByIdInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, getItemByIdInput.tableName)) {
                let remark = "table does not exist: " # debug_show(getItemByIdInput.tableName); 
                Debug.print(remark);
                return #err([ remark ]);
            };

            let table = Map.get(database.tables, thash, getItemByIdInput.tableName)!;
            // check if item exists
            if (not Map.has(table.items, thash, getItemByIdInput.id)) {
                let remark = "item does not exist" # debug_show(getItemByIdInput.id);
                Debug.print(remark);
                return #err([ remark ]);
            };

            // get item
            let item = Map.get(table.items, thash, getItemByIdInput.id)!;
            return #ok({
                id = getItemByIdInput.id;
                item = Map.toArray(item.attributeDataValueMap)
            });
        };

        Prelude.unreachable();
    };

};