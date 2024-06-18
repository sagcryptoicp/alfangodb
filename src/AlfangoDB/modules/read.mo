import Database "../types/database";
import InputTypes "../types/input";
import OutputTypes "../types/output";
import Map "mo:map/Map";
import { thash } "mo:map/Map";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

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

    public func getDatabaseNames(
        alfangoDB: Database.AlfangoDB
    ) : OutputTypes.GetDatabasesOutputType {

        // create an empty array
        var databaseNames : [Database.DatabaseName] = [];

        // crete an Iterator
        let databaseArgsIter = Iter.range(0, alfangoDB.databases.size() - 1);

        // iterate over the databases
        for (i in databaseArgsIter) {
            let databaseInfo = alfangoDB.databases.get(i);

            // check if the database Map is null
            switch(databaseInfo) {
                case (null) { };
                case (?value) {

                    // get the databases name array
                    let databases = value.0;

                    // create an Iterator
                    let dbIter = Iter.range(0, databases.size() - 1);

                    // iterate over the databases name array
                    for (j in dbIter) {

                        // check if the database name is null
                        let dbValue = databases.get(j);
                        switch(dbValue){
                            case (null) {/* TO-DO : Handle null case */ };
                            case (?value) {
                                // append the database name to the array
                                databaseNames := Array.append(databaseNames, [value]);  
                            };
                        };
                    };
                };
            };
        };
        
        return databaseNames;
    }

};