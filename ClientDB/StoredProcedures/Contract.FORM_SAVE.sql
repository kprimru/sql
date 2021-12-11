USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[FORM_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[FORM_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Contract].[FORM_SAVE]
	@ID UNIQUEIDENTIFIER OUTPUT,
	@NUM	NVARCHAR(128),
	@NAME	NVARCHAR(1024),
	@PATH	NVARCHAR(1024)
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

		IF @ID IS NULL
		BEGIN
			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

			INSERT INTO Contract.Forms(NUM, NAME, FILE_PATH)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@NUM, @NAME, @PATH)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Contract.Forms
			SET	NAME = @NAME,
				NUM = @NUM,
				FILE_PATH = @PATH
			WHERE ID = @ID
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
GRANT EXECUTE ON [Contract].[FORM_SAVE] TO rl_contract_form_u;
GO
