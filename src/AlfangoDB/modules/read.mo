import Database "../types/database";
import InputTypes "../types/input";
import OutputTypes "../types/output";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Iter "mo:base/Iter";
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


    public func batchGetItemById({
        batchGetItemByIdInput: InputTypes.BatchGetItemByIdInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.BatchGetItemByIdOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, batchGetItemByIdInput.databaseName)) {
            let remark = "database does not exist: " # debug_show(batchGetItemByIdInput.databaseName);
            Debug.print(remark);
            return #err([ remark ]);
        };

        ignore do ?{
            let database = Map.get(databases, thash, batchGetItemByIdInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, batchGetItemByIdInput.tableName)) {
                let remark = "table does not exist: " # debug_show(batchGetItemByIdInput.tableName); 
                Debug.print(remark);
                return #err([ remark ]);
            };

            let table = Map.get(database.tables, thash, batchGetItemByIdInput.tableName)!;

            let notFoundIdsBuffer = Buffer.Buffer<Text>(0);
            let items = Buffer.Buffer<OutputTypes.ItemOutputType>(0);
            for (id in batchGetItemByIdInput.ids.vals()) {
                // check if item exists
                if (not Map.has(table.items, thash, id)) {
                    let remark = "item does not exist" # debug_show(id);
                    Debug.print(remark);
                    notFoundIdsBuffer.add(id);
                };
                let item = Map.get(table.items, thash, id)!;
                items.add({
                    id = id;
                    item = Map.toArray(item.attributeDataValueMap);
                });
            };

            return #ok({
                items = Buffer.toArray(items);
                notFoundIds = Buffer.toArray(notFoundIdsBuffer);
            });
        };

        Prelude.unreachable();
    };

    public func getItemCount({
        getItemCountInput: InputTypes.GetItemCountInputType;
        alfangoDB: Database.AlfangoDB;
    }) : OutputTypes.GetItemCountOutputType {

        // get databases
        let databases = alfangoDB.databases;

        // check if database exists
        if (not Map.has(databases, thash, getItemCountInput.databaseName)) {
            let remark = "database does not exist: " # debug_show(getItemCountInput.databaseName);
            Debug.print(remark);
            return #err([ remark ]);
        };

        ignore do ?{
            let database = Map.get(databases, thash, getItemCountInput.databaseName)!;

            // check if table exists
            if (not Map.has(database.tables, thash, getItemCountInput.tableName)) {
                let remark = "table does not exist: " # debug_show(getItemCountInput.tableName); 
                Debug.print(remark);
                return #err([ remark ]);
            };

            let table = Map.get(database.tables, thash, getItemCountInput.tableName)!;

            return #ok({
                count = Map.size(table.items);
            });
        };

        Prelude.unreachable();
    };

    public func getDatabases(alfangoDB: Database.AlfangoDB) : OutputTypes.GetDatabasesOutputType {
        let databasesInfo = Buffer.Buffer<{ name: Text; tables: [Text]; }>(0);
        
        // Iterate over all databases
        for ((dbName, database) in Map.entries(alfangoDB.databases)) {
            let tableNames = Buffer.Buffer<Text>(0);
            
            // Iterate over all tables in the current database
            for ((tableName, table) in Map.entries(database.tables)) {
                tableNames.add(tableName);
            };

             // Add the database info (name and tables) to the main buffer
            databasesInfo.add({
                name = dbName;
                tables = Buffer.toArray(tableNames);
            });
        };

        return {
            databases = Buffer.toArray(databasesInfo);
        };

        Prelude.unreachable();
    };
};