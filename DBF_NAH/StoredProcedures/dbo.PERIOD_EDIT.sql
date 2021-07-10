USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 15.10.2008
��������:	  �������� ������ � ������� �
               ��������� �����
*/

ALTER PROCEDURE [dbo].[PERIOD_EDIT]
	@periodid SMALLINT,
	@periodname VARCHAR(20),
	@perioddate SMALLDATETIME,
	@periodenddate SMALLDATETIME,
	@breport	SMALLDATETIME,
	@ereport	SMALLDATETIME,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PeriodTable
	SET PR_NAME = @periodname,
		PR_DATE = @perioddate,
		PR_END_DATE = @periodenddate,
		PR_BREPORT	=	@breport,
		PR_EREPORT	=	@ereport,
		PR_ACTIVE = @active
	WHERE PR_ID = @periodid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[PERIOD_EDIT] TO rl_period_w;
GO