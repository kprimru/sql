﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CATEGORY_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CATEGORY_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CATEGORY_SAVE]
	@ID		INT OUTPUT,
	@MASTER	INT,
	@NAME	NVARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN
		INSERT INTO dbo.Category(ID_MASTER, NAME)
			VALUES(@MASTER, @NAME)

		SELECT @ID = SCOPE_IDENTITY()
	END
	ELSE
		UPDATE dbo.Category
		SET ID_MASTER	=	@MASTER,
			NAME		=	@NAME,
			LAST		=	GETDATE()
		WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[CATEGORY_SAVE] TO rl_admin;
GO