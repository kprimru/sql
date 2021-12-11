USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[JOB_START]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[JOB_START]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[JOB_START]
	@Name	VarChar(100),
	@Id		BigInt = NULL OUTPUT
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

		DECLARE @Type_Id	SmallInt;

		SELECT @Type_Id = Id
		FROM Maintenance.JobType
		WHERE Name = @Name;

		IF @Type_Id IS NULL BEGIN
			INSERT INTO Maintenance.JobType(Name)
			VALUES(@Name);

			SELECT @Type_Id = Scope_Identity();
		END;

		INSERT INTO Maintenance.Jobs([Type_Id])
		VALUES(@Type_Id);

		SELECT @Id = Scope_Identity();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[JOB_START] TO public;
GO
