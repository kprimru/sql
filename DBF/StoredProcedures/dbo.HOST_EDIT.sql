USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  �������� ������ � ����� � 
               ��������� ����� � �����������
*/

CREATE PROCEDURE [dbo].[HOST_EDIT] 
	@hostid SMALLINT,
	@hostname VARCHAR(250),
	@hostregname VARCHAR(20),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.HostTable
	SET HST_NAME = @hostname,
		HST_REG_NAME = @hostregname,
		HST_ACTIVE = @active
	WHERE HST_ID = @hostid

	SET NOCOUNT OFF
END