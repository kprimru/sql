﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USER_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USER_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[USER_SAVE]
	@ID		INT OUTPUT,
	@LGN	NVARCHAR(128),
	@SHORT	NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN
		INSERT INTO dbo.Users(LGN, SHORT)
			VALUES(@LGN, @SHORT)

		SELECT @ID = SCOPE_IDENTITY()
	END
	ELSE
		UPDATE dbo.Users
		SET LGN		=	@LGN,
			SHORT	=	@SHORT,
			LAST	=	GETDATE()
		WHERE ID = @ID
END
GO
GRANT EXECUTE ON [dbo].[USER_SAVE] TO rl_admin;
GO