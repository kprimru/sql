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

CREATE PROCEDURE [dbo].[CLIENT_ACT_SUBMIT_SELECT]
	-- ������ ���������� ���������	
AS
BEGIN
	-- SET NOCOUNT ON ���������� ��� ������������� � �������� ����������.
	-- ��������� �������� ������ ���������� � �������� ��������.

	SET NOCOUNT ON;

	-- ����� ��������� ����
	SELECT CL_ID, CL_PSEDO, CL_FULL_NAME
	FROM dbo.ClientTable
	WHERE EXISTS
		(
			SELECT * 
			FROM dbo.ActDistrView
			WHERE ACT_ID_CLIENT = CL_ID
		)
	ORDER BY CL_PSEDO, CL_ID
END


