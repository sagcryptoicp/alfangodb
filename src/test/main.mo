import AlfangoDB        "../AlfangoDB";

shared ({ caller = initializer }) actor class Test() = this {

    stable let alfangoDB = AlfangoDB.AlfangoDB();

    public shared (_msg) func updateOperation({ updateOpsInput : AlfangoDB.UpdateOpsInputType; }) : async AlfangoDB.UpdateOpsOutputType {
        return await AlfangoDB.updateOperation({ updateOpsInput; alfangoDB; });
    };

    public query (_msg) func queryOperation({ queryOpsInput : AlfangoDB.QueryOpsInputType; }) : async AlfangoDB.QueryOpsOutputType {
        return AlfangoDB.queryOperation({ queryOpsInput; alfangoDB; });
    };

};
