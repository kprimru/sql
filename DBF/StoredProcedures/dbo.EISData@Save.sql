USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EISData@Save]
    @Client_Id          Int,
    @ExpectedClient_Id  Int,
    @Data               Xml,
    @Code               VarChar(100),
    @Contract           VarChar(100),
    @RegNum             VarChar(100),
    @Url                VarChar(512)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Inn            VarChar(100)

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @Inn = (SELECT CL_INN FROM dbo.ClientTable WHERE CL_ID = @ExpectedClient_Id);

        IF @Client_Id IS NULL AND @ExpectedClient_Id IS NOT NULL BEGIN
            UPDATE dbo.ClientFinancing SET
                EIS_CODE = @Code,
                EIS_DATA = @Data,
                EIS_REG_NUM = @RegNum,
                EIS_CONTRACT = @Contract,
                EIS_LINK = @Url,
                UPD_PRINT = 1
            WHERE ID_CLIENT IN
                (
                    SELECT CL_ID
                    FROM dbo.ClientTable
                    WHERE CL_INN = @Inn
                );

            SET @Client_Id = @ExpectedClient_Id;
        END;

        IF @Client_Id IS NOT NULL
            INSERT INTO dbo.ClientFinancingEIS(Client_Id, Date, Data)
            SELECT @Client_Id, GetDate(), @Data;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EISData@Save] TO rl_distr_financing_w;
GO