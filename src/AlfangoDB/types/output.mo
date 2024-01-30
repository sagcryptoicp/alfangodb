import Datatypes "datatype";
import Database "database";
import SearchTypes "search";
import Result "mo:base/Result";

module {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type CreateDatabaseOutputType = ();

    public type CreateTableOutputType = ();

    public type CreateItemOutputType = Result.Result<Text, [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type GetTableMetadataOutputType = ?{
        databaseName: Text;
        tableName: Text;
        metadata : Database.TableMetadata;
    };

    public type GetItemByIdOutputType = ?[ (Text, Datatypes.AttributeDataValue) ];

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type ScanOutputType = ?{
        items: [ [ (Text, Datatypes.AttributeDataValue) ] ];
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    

    public type UpdateItemOutputType = Result.Result<[ (Text, Datatypes.AttributeDataValue) ], [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type UpdateOpsOutputType = {
        #CreateDatabaseOutput : CreateDatabaseOutputType;
        #CreateTableOutput : CreateTableOutputType;
        #CreateItemOutput : CreateItemOutputType;
        #UpdateItemOutput : UpdateItemOutputType;
    };

    public type QueryOpsOutputType = {
        #GetTableMetadataOutput : GetTableMetadataOutputType;
        #GetItemByIdOutput : GetItemByIdOutputType;
        #ScanOutput : ScanOutputType;
    };

};