USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[ServiceDistr]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_SALARY]    UniqueIdentifier      NOT NULL,
        [CLIENT]       NVarChar(1024)        NOT NULL,
        [ID_HOST]      Int                   NOT NULL,
        [DISTR]        Int                   NOT NULL,
        [COMP]         TinyInt               NOT NULL,
        [DISTR_STR]    NVarChar(512)         NOT NULL,
        [OPER]         NVarChar(128)         NOT NULL,
        [OPER_NOTE]    NVarChar(512)         NOT NULL,
        [PRICE_OLD]    Money                 NOT NULL,
        [PRICE_NEW]    Money                 NOT NULL,
        [WEIGHT_OLD]   decimal               NOT NULL,
        [WEIGHT_NEW]   decimal               NOT NULL,
        CONSTRAINT [PK_Salary.ServiceDistr] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Salary.ServiceDistr(ID_SALARY)_Salary.Service(ID)] FOREIGN KEY  ([ID_SALARY]) REFERENCES [Salary].[Service] ([ID]),
        CONSTRAINT [FK_Salary.ServiceDistr(ID_HOST)_dbo.Hosts(HostID)] FOREIGN KEY  ([ID_HOST]) REFERENCES [dbo].[Hosts] ([HostID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Salary.ServiceDistr(ID_SALARY)+(PRICE_OLD,PRICE_NEW,WEIGHT_OLD,WEIGHT_NEW)] ON [Salary].[ServiceDistr] ([ID_SALARY] ASC) INCLUDE ([PRICE_OLD], [PRICE_NEW], [WEIGHT_OLD], [WEIGHT_NEW]);
GO
