USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
�����:			������� �������/������ ��������
���� ��������:	4.05.2009
��������:		�������� �� ������� ������� ������������ � �������� ������
				(����� ������ �� �����)
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_CHECK_REG] 
	@dsname VARCHAR(100)  
AS
BEGIN
	SET NOCOUNT ON

	SELECT DS_ID
	FROM dbo.DistrStatusTable
	WHERE DS_REG = @dsname 

	SET NOCOUNT OFF
END








