﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[COMPANY_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[COMPANY_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[COMPANY_SAVE]
	@ID		INT OUTPUT,
	@NAME	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN
		INSERT INTO dbo.Company(NAME)
			VALUES(@NAME)

		SELECT @ID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE dbo.Company
		SET NAME	=	@NAME,
			LAST	=	GETDATE()
		WHERE ID = @ID
	END
END
GO
GRANT EXECUTE ON [dbo].[COMPANY_SAVE] TO rl_admin;
GO
