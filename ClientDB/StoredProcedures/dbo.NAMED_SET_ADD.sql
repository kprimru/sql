USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[NAMED_SET_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[NAMED_SET_ADD]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[NAMED_SET_ADD]
	@SET_NAME	NVARCHAR(128),
	@REF_NAME	NVARCHAR(128),
	@VALUES		NVARCHAR(MAX)
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

		INSERT INTO dbo.NamedSets(RefName, SetName)
		VALUES (@REF_NAME, @SET_NAME)

		DECLARE @ITEM	NVARCHAR(128)
		DECLARE @ID		UNIQUEIDENTIFIER

		SELECT @ID=SetId
		FROM dbo.NamedSets
		WHERE RefName=@REF_NAME AND SetName=@SET_NAME

        -- ToDo переделать на Split
		WHILE LEN(@VALUES)>0
		BEGIN
			IF CHARINDEX(',', @VALUES)<>0
				SET @ITEM = LEFT(@VALUES, CHARINDEX(',', @VALUES)-1)
			ELSE
				SET @ITEM = @VALUES
			IF (LEN(@VALUES)-(LEN(@ITEM)+1))>0
				SET @VALUES = SUBSTRING(@VALUES, LEN(@ITEM)+2, LEN(@VALUES)-(LEN(@ITEM)+1))
			ELSE
				SET @VALUES=''

			INSERT INTO dbo.NamedSetsItems(SetID, SetItem)
			VALUES (@ID, @ITEM)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[NAMED_SET_ADD] TO rl_named_sets_i;
GO
