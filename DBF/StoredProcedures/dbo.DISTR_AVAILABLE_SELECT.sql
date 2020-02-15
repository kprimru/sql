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

CREATE PROCEDURE [dbo].[DISTR_AVAILABLE_SELECT]
	@disid INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DIS_ID, DIS_STR, SYS_SHORT_NAME, DIS_NUM, DIS_COMP_NUM
	FROM dbo.DistrView WITH(NOEXPAND)
	WHERE NOT EXISTS
					(
						SELECT * 
						FROM dbo.ClientDistrTable
						WHERE CD_ID_DISTR = DIS_ID
					) AND DIS_ACTIVE = 1

	UNION ALL

	SELECT DIS_ID, DIS_STR, SYS_SHORT_NAME, DIS_NUM, DIS_COMP_NUM
	FROM dbo.DistrView WITH(NOEXPAND)
	WHERE DIS_ID = @disid
END
