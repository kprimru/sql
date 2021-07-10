USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[CLIENT_DISTR_DEFAULT_GET]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DSS_ID, DSS_NAME
	FROM dbo.DistrServiceStatusTable
	WHERE DSS_SUBHOST =
		(
			SELECT SH_SUBHOST
			FROM
				dbo.SubhostTable INNER JOIN
				dbo.ClientTable ON CL_ID_SUBHOST = SH_ID
			WHERE CL_ID = @clientid
		)
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DEFAULT_GET] TO rl_client_distr_r;
GO