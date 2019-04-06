USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[TYPE_SAVE]
	@ID		UNIQUEIDENTIFIER OUTPUT,
	@NAME	NVARCHAR(128),
	@PREFIX	NVARCHAR(32),
	@FORM	NVARCHAR(32),
	@CDAY	SMALLINT,
	@CMONTH	SMALLINT,
	@FORMS	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN
		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
		INSERT INTO Contract.Type(NAME, CDAY, CMONTH, PREFIX, FORM)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@NAME, @CDAY, @CMONTH, @PREFIX, @FORM)
			
		SELECT @ID = ID FROM @TBL
	END
	ELSE	
		UPDATE Contract.Type
		SET NAME	=	@NAME,
			PREFIX	=	@PREFIX,
			FORM	=	@FORM,
			CDAY	=	@CDAY,
			CMONTH	=	@CMONTH,
			LAST	=	GETDATE()
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
END
