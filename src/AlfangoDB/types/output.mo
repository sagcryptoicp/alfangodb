import Datatypes "datatype";
import SearchTypes "search";
import Result "mo:base/Result";

module {
    
    public type CreateItemOutputType = Result.Result<Text, [ Text ]>;

    public type GetItemByIdOutputType = ?[ (Text, Datatypes.AttributeDataValue) ];

    public type ScanOutputType = ?{
        items: [ [ (Text, Datatypes.AttributeDataValue) ] ];
    };

};