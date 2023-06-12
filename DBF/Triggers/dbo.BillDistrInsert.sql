﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[BillDistrInsert]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[BillDistrInsert]  ON [dbo].[BillDistrTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO

/*
Автор:		Денисов Алексей
Описание:
*/

ALTER TRIGGER [dbo].[BillDistrInsert]
   ON  [dbo].[BillDistrTable]
   AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO SaldoTable(
						SL_DATE, SL_ID_CLIENT, SL_ID_DISTR,
						SL_ID_BILL_DIS, SL_ID_IN_DIS, SL_ID_ACT_DIS, SL_REST, SL_TP, SL_BEZ_NDS)
		SELECT
			BD_DATE,
			BL_ID_CLIENT, BD_ID_DISTR, BD_ID, NULL, NULL,
			ISNULL(
				(
					SELECT TOP 1 SL_REST
					FROM SaldoTable
					WHERE SL_ID_DISTR = BD_ID_DISTR
						AND SL_ID_CLIENT = BL_ID_CLIENT
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0), 4,
			ISNULL(
				(
					SELECT TOP 1 SL_BEZ_NDS
					FROM SaldoTable
					WHERE SL_ID_DISTR = BD_ID_DISTR
						AND SL_ID_CLIENT = BL_ID_CLIENT
					ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
				), 0)
		FROM
			INSERTED INNER JOIN
			BillTable ON BD_ID_BILL = BL_ID
END

GO
