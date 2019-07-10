USE [DBF]
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

CREATE PROCEDURE [dbo].[SALDO_RECALC_ALL]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE CLIENT CURSOR LOCAL FOR 
		SELECT CL_ID 
		FROM dbo.ClientTable
		WHERE EXISTS
				(
					SELECT *
					FROM dbo.SaldoTable
					WHERE SL_ID_CLIENT = CL_ID
				)

	OPEN CLIENT

	DECLARE @clid INT

	FETCH NEXT FROM CLIENT INTO @clid

	WHILE @@FETCH_STATUS = 0 
		BEGIN
			EXEC dbo.SALDO_RECALC @clid

			FETCH NEXT FROM CLIENT INTO @clid
		END

	CLOSE CLIENT
	DEALLOCATE CLIENT
END



