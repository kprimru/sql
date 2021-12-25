USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientTypeRules@RECALCULATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ClientTypeRules@RECALCULATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ClientTypeRules@RECALCULATE]
    @Client_IDs         VarChar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @Clients Table
		(
			Id		Int		NOT NULL	Primary Key Clustered
		);

        IF @Client_IDs IS NULL
            INSERT INTO @Clients
            SELECT [ClientID]
            FROM dbo.ClientTable
            WHERE [STATUS] = 1;
        ELSE
            INSERT INTO @Clients
            SELECT DISTINCT Item
            FROM dbo.GET_TABLE_FROM_LIST(@Client_IDs, ',');

        UPDATE C SET
            [ClientTypeId] = T.[ClientTypeId]
        FROM dbo.ClientTable    C
        INNER JOIN @Clients     U   ON C.ClientId = U.Id
        OUTER APPLY
        (
            SELECT TOP (1) T.[ClientTypeID]
            FROM dbo.ClientDistrView        AS D WITH(NOEXPAND)
            INNER JOIN dbo.ClientTypeRules  AS R ON R.[System_Id] = D.[SystemID]
                                                AND R.[DistrType_Id] = D.[DistrTypeID]
            INNER JOIN dbo.ClientTypeTable  AS T ON T.[ClientTypeID] = R.[ClientType_Id]
            WHERE   C.ClientID = D.ID_CLIENT
                AND D.DS_REG = 0
            ORDER BY T.[SortIndex]
        ) T;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ClientTypeRules@RECALCULATE] TO rl_client_type_u;
GO
