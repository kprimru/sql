USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[Service]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_COURIER]   SmallInt              NOT NULL,
        [ID_PERIOD]    SmallInt              NOT NULL,
        [LAST]         DateTime              NOT NULL,
        [COEF]         decimal                   NULL,
        CONSTRAINT [PK_Salary.Service] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Salary.Service(ID_COURIER)_Salary.CourierTable(COUR_ID)] FOREIGN KEY  ([ID_COURIER]) REFERENCES [dbo].[CourierTable] ([COUR_ID]),
        CONSTRAINT [FK_Salary.Service(ID_PERIOD)_Salary.PeriodTable(PR_ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
