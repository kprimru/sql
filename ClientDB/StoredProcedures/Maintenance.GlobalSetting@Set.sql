USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalSetting@Set]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[GlobalSetting@Set]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Maintenance].[GlobalSetting@Set]
	@Name	VarChar(128),
	@Value	Sql_Variant
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

		MERGE [Maintenance].[GlobalSettings] AS S
		USING
		(
			SELECT
				[Name]	= @Name,
				[Value] = @Value
		) AS U ON S.[Name] = U.[Name]
		WHEN MATCHED AND U.[Value] != S.[Value] THEN UPDATE SET
			[Value] = U.[Value],
			[Last] = GetDate()
		WHEN NOT MATCHED THEN
			INSERT([Name], [Value], [GS_NOTE])
			VALUES(U.[Name], U.[Value], '');

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
