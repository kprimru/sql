USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceStateDetail]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_STATE]    UniqueIdentifier      NOT NULL,
        [TP]          NVarChar(64)          NOT NULL,
        [ID_CLIENT]   Int                   NOT NULL,
        [DETAIL]      NVarChar(Max)             NULL,
        CONSTRAINT [PK_dbo.ServiceStateDetail] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ServiceStateDetail(ID_STATE)+(TP,ID_CLIENT,DETAIL)] ON [dbo].[ServiceStateDetail] ([ID_STATE] ASC) INCLUDE ([TP], [ID_CLIENT], [DETAIL]);
GO
