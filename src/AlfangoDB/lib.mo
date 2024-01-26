import Datatypes "types/datatype";
import Database "types/database";
import InputTypes "types/input";
import Create "modules/create";
import Read "modules/read";
import Update "modules/update";
import Delete "modules/delete";

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
    public type GetItemByIdInputType = InputTypes.GetItemByIdInputType;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public let { createDatabase; createTable; createItem; } = Create;
    public let { getItemById; } = Read;
    public let {} = Update;
    public let {} = Delete;

};