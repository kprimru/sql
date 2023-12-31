USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		������� �������
��������:
*/

ALTER TRIGGER [dbo].[ActDistrInsert]
   ON  [dbo].[ActDistrTable]
   AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO SaldoTable(
						SL_DATE, SL_ID_CLIENT, SL_ID_DISTR,
						SL_ID_ACT_DIS, SL_REST, SL_TP, SL_BEZ_NDS)
		SELECT
			ACT_DATE,
			ACT_ID_CLIENT, AD_ID_DISTR, AD_ID,
			ISNULL(
				(
					SELECT TOP 1 SL_REST
					FROM SaldoTable
					WHERE SL_ID_DISTR = AD_ID_DISTR
						AND SL_ID_CLIENT = ACT_ID_CLIENT
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0) - AD_TOTAL_PRICE, 3,
			ISNULL(
				(
					SELECT TOP 1 SL_BEZ_NDS
					FROM SaldoTable
					WHERE SL_ID_DISTR = AD_ID_DISTR
						AND SL_ID_CLIENT = ACT_ID_CLIENT
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0) - AD_PRICE
		FROM
			INSERTED INNER JOIN
			ActTable ON AD_ID_ACT = ACT_ID
END


GO
