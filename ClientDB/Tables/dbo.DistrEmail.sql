USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrEmail]
(
        [Id]        Int             Identity(1,1)   NOT NULL,
        [HostId]    Int                                 NULL,
        [Distr]     Int                                 NULL,
        [Comp]      TinyInt                             NULL,
        [Date]      SmallDateTime                       NULL,
        [Email]     VarChar(128)                        NULL,
        [UpdUser]   NVarChar(256)                       NULL,
        CONSTRAINT [PK__DistrEma__3214EC0683860D9D] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE CLUSTERED INDEX [ClusteredIndex-20230513-132759] ON [dbo].[DistrEmail] ([HostId] ASC, [Distr] ASC, [Comp] ASC, [Date] ASC);
GO
