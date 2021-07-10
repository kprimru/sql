USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[VERIFY_DEFAULT_GET]
	@clientid INT,
	@date SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		ORG_ID, ORG_SHORT_NAME, dbo.GET_SETTING('ORG_BUH') AS BUH_NAME,
		CL_FULL_NAME,
		(
			SELECT SUM(SL_REST)
			FROM
				(
					SELECT
						ISNULL((
							SELECT TOP 1 SL_REST
							FROM dbo.SaldoTable b
							WHERE SL_ID_CLIENT = @clientid
								AND a.SL_ID_DISTR = b.SL_ID_DISTR
								AND SL_DATE < @date
							ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
							), 0) AS SL_REST
					FROM
						(
							SELECT DISTINCT SL_ID_DISTR
							FROM dbo.SaldoTable
							WHERE SL_ID_CLIENT = @clientid
						) AS a
				) AS O_O
		) AS SL_REST
	FROM
		dbo.ClientTable LEFT OUTER JOIN
		dbo.OrganizationTable ON CL_ID_ORG = ORG_ID
	WHERE CL_ID = @clientid
END




GO
GRANT EXECUTE ON [dbo].[VERIFY_DEFAULT_GET] TO rl_report_verify_r;
GO