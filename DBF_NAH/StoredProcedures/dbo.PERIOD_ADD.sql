USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 15.10.2008
��������:	  �������� ������ � ����������
*/

ALTER PROCEDURE [dbo].[PERIOD_ADD]
	@periodname VARCHAR(20),
	@perioddate SMALLDATETIME,
	@periodenddate SMALLDATETIME,
	@breport	SMALLDATETIME,
	@ereport	SMALLDATETIME,
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.PeriodTable(
			PR_NAME, PR_DATE, PR_END_DATE, PR_BREPORT, PR_EREPORT, PR_ACTIVE)
	VALUES (@periodname, @perioddate, @periodenddate, @breport, @ereport, @active)

	IF @returnvalue = 1
	  SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[PERIOD_ADD] TO rl_period_w;
GO