USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Contract].[TYPE_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Contract].[TYPE_SAVE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Contract].[TYPE_SAVE]
	@ID		UNIQUEIDENTIFIER OUTPUT,
	@NAME	NVARCHAR(128),
	@PREFIX	NVARCHAR(32),
	@FORM	NVARCHAR(32),
	@CDAY	SMALLINT,
	@CMONTH	SMALLINT,
	@FORMS	NVARCHAR(MAX) = NULL,
	@CTYPE	INT = NULL,
	@PTYPE	INT = NULL
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
			INSERT INTO Contract.Type(NAME, CDAY, CMONTH, PREFIX, FORM, Type_Id, PayType_Id)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@NAME, @CDAY, @CMONTH, @PREFIX, @FORM, @CTYPE, @PTYPE)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
			UPDATE Contract.Type
			SET NAME	=	@NAME,
				PREFIX	=	@PREFIX,
				FORM	=	@FORM,
				CDAY	=	@CDAY,
				CMONTH	=	@CMONTH,
				Type_Id =	@CTYPE,
				PayType_Id = @PTYPE
			WHERE ID = @ID

		DELETE
		FROM Contract.TypeForms
		WHERE ID_TYPE = @ID
			AND ID_FORM NOT IN
				(
					SELECT a.ID
					FROM dbo.TableGUIDFromXML(@FORMS) AS a
				)

		INSERT INTO Contract.TypeForms(ID_TYPE, ID_FORM)
			SELECT @ID, a.ID
			FROM dbo.TableGUIDFromXML(@FORMS) AS a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Contract.TypeForms
					WHERE ID_TYPE = @ID
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
GRANT EXECUTE ON [Contract].[TYPE_SAVE] TO rl_contract_type_u;
GO
