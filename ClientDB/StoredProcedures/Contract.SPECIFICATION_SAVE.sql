USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Contract].[SPECIFICATION_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@NUM		NVARCHAR(128),
	@NAME		NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
	@FILE_PATH	NVARCHAR(512),
	@FORMS		NVARCHAR(MAX) = NULL
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

			INSERT INTO Contract.Specification(NUM, NAME, NOTE, FILE_PATH)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@NUM, @NAME, @NOTE, @FILE_PATH)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
			UPDATE Contract.Specification
			SET NUM			=	@NUM,
				NAME		=	@NAME,
				NOTE		=	@NOTE,
				FILE_PATH	=	@FILE_PATH
			WHERE ID = @ID

		DELETE
		FROM Contract.SpecificationForms
		WHERE ID_SPECIFICATION = @ID
			AND ID_FORM NOT IN
				(
					SELECT a.ID
					FROM dbo.TableGUIDFromXML(@FORMS) AS a
				)

		INSERT INTO Contract.SpecificationForms(ID_SPECIFICATION, ID_FORM)
			SELECT @ID, a.ID
			FROM dbo.TableGUIDFromXML(@FORMS) AS a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Contract.SpecificationForms
					WHERE ID_SPECIFICATION = @ID
						AND ID_FORM = a.ID
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Contract].[SPECIFICATION_SAVE] TO rl_contract_specification_u;
GO