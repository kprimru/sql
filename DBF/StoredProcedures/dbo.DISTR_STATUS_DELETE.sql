USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 30.01.2009
��������:	  ������� ������ ������������
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_DELETE] 
	@distrstatusid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.DistrStatusTable 
	WHERE DS_ID = @distrstatusid

	SET NOCOUNT OFF
END