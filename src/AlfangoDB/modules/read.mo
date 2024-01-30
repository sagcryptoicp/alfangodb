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
                metadata = table.metadata;
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
            Debug.print("database does not exist");
            return null;
        };

        do ?{
            let database = Map.get(databases, thash, getItemByIdInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, getItemByIdInput.tableName)) {
                Debug.print("table does not exist");
                return null;
            };

            let table = Map.get(database.tables, thash, getItemByIdInput.tableName)!;
            // check if item exists
            if (not Map.has(table.items, thash, getItemByIdInput.id)) {
                Debug.print("item does not exist");
                return null;
            };

            // get item
            let item = Map.get(table.items, thash, getItemByIdInput.id)!;
            return ?Map.toArray(item.attributeDataValueMap);
        };
    };

};