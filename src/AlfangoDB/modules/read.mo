import Database "../types/database";
import InputTypes "../types/input";
import OutputTypes "../types/output";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Output "../types/output";

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

    public func getDatabaseInfo(
        alfangoDB: Database.AlfangoDB
    ) : OutputTypes.GetDatabasesOutputType {

        // create an empty array
        var databasesInfo : [
            {
                name: Text;
                tables: [Text];
            }
        ] = [];

        // crete an Iterator
        let databaseArgsIter = Iter.range(0, alfangoDB.databases.size() - 1);

        // iterate over the databases
        for (i in databaseArgsIter) {
            let databaseInfo = alfangoDB.databases.get(i);

            // check if the database Map is null
            switch(databaseInfo) {
                case (null) { };
                case (?value) {

                    // get the databases array
                    let databases = value.1;

                    // create an Iterator
                    let dbIter = Iter.range(0, databases.size() - 1);

                    // iterate over the databases array
                    for (j in dbIter) {

                        // check if the database is null
                        let dbValue = databases.get(j);
                        switch(dbValue){
                            case (null) {/* TO-DO : Handle null case */ };
                            case (?value) {

                                // get the tables array
                                let tables = value.tables;
                                let tbIter = Iter.range(0, tables.size()-1); 

                                // create an empty array
                                var tableNames : [Text] = [];

                                // iterate over the tables
                                for(k in tbIter){
                                    let tbValue = tables.get(k);
                                    switch(tbValue){
                                        case (null) {/* TO-DO : Handle null case */ };
                                        case (?value) {
                                            // get the tables name array
                                            let tables = value.0;
                                            let tbnameIter = Iter.range(0, tables.size()-1);

                                            // iterate over tables name array
                                            for(l in tbnameIter){
                                                let tbnameValue = tables.get(l);
                                                switch(tbnameValue){
                                                    case (null) {/* TO-DO : Handle null case */ };
                                                    case (?value) { 
                                                        // append the table name to the array
                                                        tableNames := Array.append(tableNames, [value]);
                                                    };
                                                };
                                            };
                                        };
                                    }
                                };

                                // append the database name and it's tables to the array
                                databasesInfo := Array.append(databasesInfo, [{
                                    name = value.name;
                                    tables = tableNames;
                                }]);
                            };
                        };
                    };
                };
            };
        };
        
        return {
            databases = databasesInfo;
        };
    };
};