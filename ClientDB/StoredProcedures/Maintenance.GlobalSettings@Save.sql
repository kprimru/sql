USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalSettings@Save]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[GlobalSettings@Save]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[GlobalSettings@Save]
    @Data	NVarChar(Max)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@RowIndex		SmallInt,
		@Name			VarChar(128),
		@Value			VarChar(256),
		@DataType		VarChar(128),
		@ValueSql		Sql_Variant;

	DECLARE @Settings Table
	(
		[Row:Index]		SmallInt Identity(1,1),
		[Name]			VarChar(128),
		[Value]			VarChar(256),
		[DataType]		VarChar(128)
	);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

		INSERT INTO @Settings([Name], [Value], [DataType])
		SELECT P.[Name], P.[Value], P.[DataType]
		FROM [Maintenance].[GlobalSettings@Parse](@Data) AS P;

		SET @RowIndex = 0;

		WHILE (1 = 1) BEGIN
			SELECT TOP (1)
				@RowIndex	= S.[Row:Index],
				@Name		= S.[Name],
				@Value		= S.[Value],
				@DataType	= S.[DataType]
			FROM @Settings AS S
			WHERE S.[Row:Index] > @RowIndex
			ORDER BY
				S.[Row:Index];

			IF @@RowCount < 1
				BREAK;

			SET @ValueSql = [Common].[VarCharToSqlVariant](@Value, @DataType);

			EXEC [Maintenance].[GlobalSetting@Set]
				@Name	= @Name,
				@Value	= @ValueSql;
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
