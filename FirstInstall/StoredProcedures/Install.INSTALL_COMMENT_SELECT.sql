USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_COMMENT_SELECT]
	@IND_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IC_ID, IC_DATE, IC_USER, IC_TEXT, CL_NAME
	FROM
		Install.InstallComments INNER JOIN
		Install.InstallDetail ON IND_ID = IC_ID_IND INNER JOIN
		Install.Install ON INS_ID = IND_ID_INSTALL INNER JOIN
		Clients.ClientLast ON CL_ID_MASTER = INS_ID_CLIENT
	WHERE IC_ID_IND = @IND_ID
END
GO
GRANT EXECUTE ON [Install].[INSTALL_COMMENT_SELECT] TO rl_install_comment_r;
GO