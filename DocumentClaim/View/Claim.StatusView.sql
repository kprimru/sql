USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[StatusView]', 'V ') IS NULL EXEC('CREATE VIEW [Claim].[StatusView]  AS SELECT 1')
GO
ALTER VIEW [Claim].[StatusView]
AS
	/*
		1 - заявка создана
		2 - заявка принята (возможно, с корректировками)
		3 - заявка выполнена
		4 - все забрали, заявка завершена
		5 - заявка отклонена
		6 - заявка отменена
		7 - заявка не подтверждена начальником отдела
	*/
	SELECT 1 AS STATUS, 2 AS INDX, 'CREATE' AS PSEDO, 'Заказ создан' AS STATUS_NAME, 1 AS UPDATING
	UNION ALL
	SELECT 2 AS STATUS, 14 AS INDX, 'APPLY' AS PSEDO, 'Заказ принят' AS STATUS_NAME, 0 AS UPDATING
	UNION ALL
	SELECT 3 AS STATUS, 0 AS INDX, 'EXECUTE' AS PSEDO, 'Заказ выполнен' AS STATUS_NAME, 0 AS UPDATING
	UNION ALL
	SELECT 4 AS STATUS, 36 AS INDX, 'FINISH' AS PSEDO, 'Заказ завершен' AS STATUS_NAME, 0 AS UPDATING
	UNION ALL
	SELECT 5 AS STATUS, 6 AS INDX, 'REJECT' AS PSEDO, 'Заказ отклонен' AS STATUS_NAME, 0 AS UPDATING
	UNION ALL
	SELECT 6 AS STATUS, 1 AS INDX, 'CANCEL' AS PSEDO, 'Заказ отменен' AS STATUS_NAME, 0 AS UPDATING
	UNION ALL
	SELECT 7 AS STATUS, 13 AS INDX, 'VERIFY' AS PSEDO, 'Заказ не подтвержден' AS STATUS_NAME, 1 AS UPDATING
	UNION ALL
	SELECT 8 AS STATUS, 47 AS INDX, 'REMAKE' AS PSEDO, 'Заказ подтвердить' AS STATUS_NAME, 1 AS UPDATINGGO
