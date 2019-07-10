USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:		  ������� �������
��������:	  
*/
CREATE PROCEDURE [dbo].[DISTR_FINANCING_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		DF_ID, DIS_STR, DIS_ID, SN_ID, 
		SN_NAME, PP_ID, PP_NAME, DF_MON_COUNT,
		DF_FIXED_PRICE, DF_DISCOUNT, PR_DATE AS DF_FIRST_MON, DSS_NAME,
		(
			SELECT TOP 1 CO_NUM
			FROM 
				dbo.ContractTable INNER JOIN
				dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID
			WHERE CO_ID_CLIENT = @clientid
				AND COD_ID_DISTR = DIS_ID
				AND CO_ACTIVE = 1
			ORDER BY CO_END_DATE DESC
		) AS CO_NUM, 
		(
			SELECT TOP 1 CO_END_DATE
			FROM 
				dbo.ContractTable INNER JOIN
				dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID
			WHERE CO_ID_CLIENT = @clientid
				AND COD_ID_DISTR = DIS_ID
				AND CO_ACTIVE = 1
			ORDER BY CO_END_DATE DESC
		) AS CO_END_DATE, 
		(
			SELECT COUR_NAME
			FROM 
				dbo.CourierTable INNER JOIN
				dbo.TOTable ON TO_ID_COUR = COUR_ID INNER JOIN
				dbo.TODistrTable ON TD_ID_TO = TO_ID
			WHERE TD_ID_DISTR = DIS_ID
		)AS COUR_NAME, DF_EXCHANGE, DF_END, DF_BEGIN,
		(
			SELECT TO_NUM
			FROM 
				dbo.TODistrView z
				INNER JOIN dbo.TOTable y ON z.TD_ID_TO = y.TO_ID
			WHERE z.DIS_ID = a.DIS_ID
		) AS TO_NUM
	FROM dbo.DistrFinancingView a
	WHERE CD_ID_CLIENT = @clientid
			AND DIS_ACTIVE = 1
	ORDER BY DIS_STR

	SET NOCOUNT OFF
END

























