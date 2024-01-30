import Map              "mo:map/Map";
import Prelude          "mo:base/Prelude";
import Result           "mo:base/Result";
import { thash }        "mo:map/Map";
import AlfangoDB        "../AlfangoDB";

shared ({ caller = initializer }) actor class Test() = this {

    stable let alfangoDB = AlfangoDB.AlfangoDB();

    public shared (msg) func createDatabase(args : AlfangoDB.CreateDatabaseInputType) : async () {
        AlfangoDB.createDatabase({ createDatabaseInput = args; alfangoDB; });
    };

    public shared (msg) func createTable(args : AlfangoDB.CreateTableInputType) : async () {
        AlfangoDB.createTable({ createTableInput = args; alfangoDB; });
    };

    public shared (msg) func createItem(args : AlfangoDB.CreateItemInputType) : async AlfangoDB.CreateItemOutputType {
        await AlfangoDB.createItem({ createItemInput = args; alfangoDB; });
    };

    public query (msg) func getItemById(args : AlfangoDB.GetItemByIdInputType) : async AlfangoDB.GetItemByIdOutputType {
        AlfangoDB.getItemById({ getItemByIdInput = args; alfangoDB; });
    };

    public query (msg) func scan(args : AlfangoDB.ScanInputType) : async AlfangoDB.ScanOutputType {
        AlfangoDB.scan({ scanInput = args; alfangoDB; });
    };

    public shared (msg) func updateOperation({ updateOpsInput : AlfangoDB.UpdateOpsInputType; }) : async AlfangoDB.UpdateOpsOutputType {
        return await AlfangoDB.updateOperation({ updateOpsInput; alfangoDB; });
    };

    public query (msg) func queryOperation({ queryOpsInput : AlfangoDB.QueryOpsInputType; }) : async AlfangoDB.QueryOpsOutputType {
        return AlfangoDB.queryOperation({ queryOpsInput; alfangoDB; });
    };

};
