USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 24.09.2008
��������:	  �������� ��� �������
               ������� � ����������
*/

ALTER PROCEDURE [dbo].[SYSTEM_TYPE_ADD]
	@systemtypename VARCHAR(20),
	@systemtypecaption VARCHAR(100),
	@systemtypelst VARCHAR(20),
	@systemtypereport BIT,
	@order SMALLINT,
	@mosid SMALLINT,
	@subid SMALLINT,
	@host SMALLINT,
	@dhost	SMALLINT,
	@coef BIT,
	@calc DECIMAL(4, 2),
	@kbu BIT,
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.SystemTypeTable(SST_NAME, SST_CAPTION, SST_LST, SST_REPORT, SST_ACTIVE, SST_ORDER, SST_ID_MOS, SST_ID_SUB, SST_ID_HOST, SST_ID_DHOST, SST_COEF, SST_CALC, SST_KBU)
	VALUES (@systemtypename, @systemtypecaption, @systemtypelst, @systemtypereport, @active, @order, @mosid, @subid, @host, @dhost, @coef, @calc, @kbu)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_ADD] TO rl_system_type_w;
GO