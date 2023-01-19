USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ConsignmentDetailInsert]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[ConsignmentDetailInsert]  ON [dbo].[ConsignmentDetailTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
/*
Автор:		Денисов Алексей
Описание:
*/

ALTER TRIGGER [dbo].[ConsignmentDetailInsert]
   ON  [dbo].[ConsignmentDetailTable]
   AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @clientid INT

	INSERT INTO SaldoTable(
						SL_DATE, SL_ID_CLIENT, SL_ID_DISTR,
						SL_ID_CONSIG_DIS, SL_REST, SL_TP, SL_BEZ_NDS)
		SELECT
			CSG_DATE, CSG_ID_CLIENT, CSD_ID_DISTR, CSD_ID,
			ISNULL(
				(
					SELECT TOP 1 SL_REST
					FROM SaldoTable
					WHERE SL_ID_DISTR = CSD_ID_DISTR
						AND SL_ID_CLIENT = CSG_ID_CLIENT
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0) - CSD_TOTAL_PRICE, 2,
				ISNULL(
				(
					SELECT TOP 1 SL_BEZ_NDS
					FROM SaldoTable
					WHERE SL_ID_DISTR = CSD_ID_DISTR
						AND SL_ID_CLIENT = CSG_ID_CLIENT
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0) - CSD_PRICE
		FROM
			INSERTED INNER JOIN
			ConsignmentTable ON CSG_ID = CSD_ID_CONS
		WHERE CSD_ID_DISTR IS NOT NULL
END
GO
