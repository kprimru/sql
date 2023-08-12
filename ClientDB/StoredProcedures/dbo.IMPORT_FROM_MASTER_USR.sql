USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[IMPORT_FROM_MASTER_USR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[IMPORT_FROM_MASTER_USR]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[IMPORT_FROM_MASTER_USR]
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @SH_ID VarChar(10);

    DECLARE @UD_ID      Int;
    DECLARE @Path       VarChar(1000)
    DECLARE @UF_NAME    VarChar(100);
    DECLARE @Command    NVarCHar(4000);
    DECLARE @Init       Int;
    DECLARE @UF_DATA    VarBinary(Max);

    SET @SH_ID = Cast([System].[Setting@Get]('SUBHOST_NAME') AS VarChar(128));

    DELETE FROM USR.USRFromMaster;

    INSERT INTO USR.USRFromMaster
    EXEC [PC275-SQL\ALPHA].[ClientDB].[USR].[USR_SUBHOST_SELECT] NULL, @SH_ID;

    SET @UD_ID = 0;
    SET @Path = 'C:\data\' + @SH_ID + '\';

    SET @Command = 'del ' + @Path + '*.usr';

    EXEC xp_cmdshell @Command, no_output;

    WHILE (1 = 1) BEGIN
        SELECT TOP (1)
            @UD_ID      = UD_ID,
            @UF_NAME    = UF_NAME,
            @UF_DATA    = UF_DATA
        FROM USR.USRFromMaster
        WHERE UD_ID > @UD_ID
        ORDER BY
            UD_ID;

        IF @@RowCount = 0
            BREAK;

        /*
        SET @Command = 'bcp "SELECT UF_DATA FROM ClientDB.USR.USRFromMaster WHERE UD_ID = ' + convert(VarChar(20), @UD_ID) + '" queryout "' + @Path + @UF_NAME + '" -f C:\Data\bcp.fmt -T -S ' + @@ServerName;

        EXEC xp_cmdshell @Command, no_output;
        */
        SET @Command = @Path + @UF_NAME;
        SET @init = NULL;

        EXEC sp_OACreate 'ADODB.Stream', @Init OUTPUT; -- An instace created
        EXEC sp_OASetProperty @init, 'Type', 1;
        EXEC sp_OAMethod @init, 'Open'; -- Calling a method
        EXEC sp_OAMethod @init, 'Write', NULL, @UF_DATA; -- Calling a method
        EXEC sp_OAMethod @init, 'SaveToFile', NULL, @Command, 2; -- Calling a method
        EXEC sp_OAMethod @init, 'Close'; -- Calling a method
        EXEC sp_OADestroy @init; -- Closed the resources
    END;
END
GO
