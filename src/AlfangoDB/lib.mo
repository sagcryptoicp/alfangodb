import Datatypes "types/datatype";
import Database "types/database";
import InputTypes "types/input";
import OutputTypes "types/output";
import SearchTypes "types/search";
import Create "modules/create";
import Read "modules/read";
import Update "modules/update";
import Delete "modules/delete";
import Search "modules/search";

module {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type DefaultAttributeDataType = Datatypes.DefaultAttributeDataType;
    public type DefaultAttributeDataValue = Datatypes.DefaultAttributeDataValue;

    public type NumericAttributeDataType = Datatypes.NumericAttributeDataType;
    public type NumericAttributeDataValue = Datatypes.NumericAttributeDataValue;

    public type StringAttributeDataType = Datatypes.StringAttributeDataType;
    public type StringAttributeDataValue = Datatypes.StringAttributeDataValue;

    public type ListAttributeDataType = Datatypes.ListAttributeDataType;
    public type ListAttributeDataValue = Datatypes.ListAttributeDataValue;

    public type MiscAttributeDataType = Datatypes.MiscAttributeDataType;
    public type MiscAttributeDataValue = Datatypes.MiscAttributeDataValue;

    public type AttributeDataType = Datatypes.AttributeDataType;
    public type AttributeDataValue = Datatypes.AttributeDataValue;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type AttributeMetadata = Database.AttributeMetadata;
    public type TableIndexMetadata = Database.TableIndexMetadata;
    public type TableMetadata = Database.TableMetadata;
    public type Item = Database.Item;
    public type Index = Database.Index;
    public type Table = Database.Table;
    public type Database = Database.Database;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type AlfangoDB = Database.AlfangoDB;
    public let AlfangoDB = Database.AlfangoDB;

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

    public type CreateDatabaseInputType = InputTypes.CreateDatabaseInputType;
    public type CreateTableInputType = InputTypes.CreateTableInputType;
    public type CreateItemInputType = InputTypes.CreateItemInputType;
    public type CreateItemOutputType = OutputTypes.CreateItemOutputType;

    public let { createDatabase; createTable; createItem; } = Create;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type GetItemByIdInputType = InputTypes.GetItemByIdInputType;
    public type GetItemByIdOutputType = OutputTypes.GetItemByIdOutputType;

    public let { getItemById; } = Read;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type RelationalExpressionAttributeDataValue = SearchTypes.RelationalExpressionAttributeDataValue;
    public type FilterExpressionConditionType = SearchTypes.FilterExpressionConditionType;

    public type ScanInputType = InputTypes.ScanInputType;
    public type ScanOutputType = OutputTypes.ScanOutputType;

    public let { scan; } = Search;
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public let {} = Update;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public let {} = Delete;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

};