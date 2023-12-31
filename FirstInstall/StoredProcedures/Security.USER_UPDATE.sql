USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_UPDATE]
	@US_ID		UNIQUEIDENTIFIER,
	@US_NAME	VARCHAR(50),
	@US_LOGIN	VARCHAR(50),
	@US_NOTE	VARCHAR(250),
	@US_DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	UPDATE	Security.UserDetail
	SET		US_NAME		=	@US_NAME,
			US_LOGIN	=	@US_LOGIN,
			US_NOTE		=	@US_NOTE,
			US_DATE		=	@US_DATE
	WHERE	US_ID		=	@US_ID

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT	@MASTERID = US_ID_MASTER
	FROM	Security.UserDetail
	WHERE	US_ID	=	@US_ID

	UPDATE	Security.Users
	SET		USMS_LAST	=	GETDATE()
	WHERE	USMS_ID	=	@MASTERID
END

GO
GRANT EXECUTE ON [Security].[USER_UPDATE] TO rl_user_u;
GO
