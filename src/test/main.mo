import Map              "mo:map/Map";
import Prelude          "mo:base/Prelude";
import Result           "mo:base/Result";
import { thash }        "mo:map/Map";
import AlfangoDB        "../AlfangoDB";

shared ({ caller = initializer }) actor class Test() = this {

    stable let alfangoDB = AlfangoDB.AlfangoDB();

    public shared (msg) func updateOperation({ updateOpsInput : AlfangoDB.UpdateOpsInputType; }) : async AlfangoDB.UpdateOpsOutputType {
        return await AlfangoDB.updateOperation({ updateOpsInput; alfangoDB; });
    };

    public query (msg) func queryOperation({ queryOpsInput : AlfangoDB.QueryOpsInputType; }) : async AlfangoDB.QueryOpsOutputType {
        return AlfangoDB.queryOperation({ queryOpsInput; alfangoDB; });
    };

};
