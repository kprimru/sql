USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  ���������� ����� � ��������� 
                ���������. 
*/

CREATE PROCEDURE [dbo].[HOST_CHECK_NAME] 
	@hostname VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON

	SELECT HST_ID
	FROM dbo.HostTable
	WHERE HST_NAME = @hostname

	SET NOCOUNT OFF
END