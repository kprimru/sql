USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_SALDO_LAST_SELECT]
	@clientid INT,
	@date SMALLDATETIME = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Psedo VarChar(100);
	SELECT @Psedo = CL_PSEDO
	FROM dbo.ClientTable
	WHERE CL_ID = @ClientID;

	SELECT
		@ClientID AS CL_ID, DIS_ID, @Psedo AS CL_PSEDO, DIS_STR, SN_ID, SN_NAME,
		ISNULL(
        	(
    			SELECT TOP 1 SL_REST
	        	FROM dbo.SaldoView b
		        WHERE b.SL_ID_DISTR = a.SL_ID_DISTR
    		    	AND b.SL_ID_CLIENT = @ClientID
					AND SL_DATE <= @date
        		ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
		    ), 0) AS SL_REST
	FROM
	(
		SELECT DISTINCT SL_ID_DISTR
		FROM dbo.SaldoTable
		WHERE SL_ID_CLIENT = @clientid
			AND SL_DATE <= @date
	) a
	INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR
	LEFT JOIN dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID
	LEFT JOIN dbo.SystemNetTable ON SN_ID = DF_ID_NET
	ORDER BY SYS_ORDER, DIS_STR
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SALDO_LAST_SELECT] TO rl_saldo_r;
GO