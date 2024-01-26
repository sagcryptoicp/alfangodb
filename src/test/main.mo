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

    public shared (msg) func createItem(args : AlfangoDB.CreateItemInputType) : async Result.Result<Text, [ Text ]> {
        await AlfangoDB.createItem({ createItemInput = args; alfangoDB; });
    };

    public shared (msg) func getItemById(args : AlfangoDB.GetItemByIdInputType) : async ?[ (Text, AlfangoDB.AttributeDataValue) ] {
        AlfangoDB.getItemById({ getItemByIdInput = args; alfangoDB; });
    };
};
