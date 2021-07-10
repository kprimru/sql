USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
�����:			������� �������/������ ��������
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[BILL_DELETE]
	@billid INT,
	@soid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.SaldoTable
	WHERE SL_ID_BILL_DIS IN
			(
				SELECT BD_ID
				FROM
					dbo.BillDistrTable INNER JOIN
					dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR
				WHERE BD_ID_BILL = @billid
					AND SYS_ID_SO = @soid
			)
	-- ����� ��������� ����
	DELETE
	FROM dbo.BillDistrTable
	WHERE BD_ID_BILL = @billid
		AND BD_ID_DISTR IN
			(
				SELECT DIS_ID
				FROM dbo.DistrView WITH(NOEXPAND)
				WHERE SYS_ID_SO = @soid
			)

	IF NOT EXISTS
		(
			SELECT *
			FROM dbo.BillDistrTable
			WHERE BD_ID_BILL = @billid
		)
		DELETE
		FROM dbo.BillTable
		WHERE BL_ID = @billid
END
GO
GRANT EXECUTE ON [dbo].[BILL_DELETE] TO rl_bill_d;
GO